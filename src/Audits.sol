// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAudits} from "./IAudits.sol";

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Audits is IAudits, Ownable {
    using SafeERC20 for IERC20;

    // @notice audit id => Audit.
    mapping(uint256 => Audit) public audits;
    // @notice audit id => phase => confirmed or not confirmed
    mapping(uint256 => mapping(uint256 => Phase)) public phases;
    // @notice current audit id.
    uint256 private _currentAuditId;
    // @notice max phases allowed per audit.
    uint256 private _maxPhases;

    constructor(uint256 maxPhases) {
        _maxPhases = maxPhases;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function proposeAudit(address client, address token, uint256 amount, uint256 totalPhases)
        external
        onlyOwner
        returns (uint256)
    {
        if (client == address(0)) revert AddressZero();
        if (token == address(0)) revert AddressZero();
        if (amount == 0) revert ZeroAmount();
        if (totalPhases > _maxPhases) revert ExceededMaxPhases();

        uint256 amountPerPhase = amount / totalPhases;
        Audit memory audit = Audit(client, token, amount, amountPerPhase, totalPhases, 0, false, false);

        _currentAuditId++;
        audits[_currentAuditId] = audit;

        return _currentAuditId;
    }

    function approveAudit(uint256 auditId) external {
        Audit storage audit = audits[auditId];

        if (msg.sender != audit.client) revert AuditInvalidClient();
        if (audit.confirmed == true) revert AuditAlreadyConfirmed();

        audit.confirmed = true;

        IERC20(audit.token).safeTransferFrom(audit.client, address(this), audit.amount);
    }

    function cancelAudit(uint256 auditId) external {
        Audit storage audit = audits[auditId];

        if (msg.sender != audit.client) revert AuditInvalidClient();
        if (audit.confirmed == false) revert AuditNotYetConfirmed();
        if (audit.finished == true) revert AuditAlreadyFinished();

        uint256 amount = audit.amount;

        audit.finished = true;
        audit.amount = 0;

        IERC20(audit.token).safeTransfer(audit.client, amount);
    }

    function submitPhase(uint256 auditId) external onlyOwner {
        Audit memory audit = audits[auditId];
        Phase storage phase = phases[auditId][audit.currentPhase];

        if (phase.confirmed == true) revert PhaseAlreadyConfirmed();
        if (phase.submitted == true) revert PhaseAlreadySubmitted();

        phase.submitted = true;
    }

    function approvePhase(uint256 auditId) external {
        Audit storage audit = audits[auditId];
        Phase storage phase = phases[auditId][audit.currentPhase];

        if (msg.sender != audit.client) revert AuditInvalidClient();
        if (audit.finished == true) revert AuditAlreadyFinished();
        if (phase.submitted == false) revert PhaseNotYetSubmitted();
        if (phase.confirmed == true) revert PhaseAlreadyConfirmed();

        phase.confirmed = true;
        audit.currentPhase += 1;
        audit.amount -= audit.amountPerPhase;

        if (audit.currentPhase == audit.totalPhases) {
            audit.finished = true;
        }

        IERC20(audit.token).safeTransfer(owner(), audit.amountPerPhase);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                GETTERS / SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function setMaxPhases(uint256 maxPhases) external onlyOwner {
        _maxPhases = maxPhases;
    }

    function getAudit(uint256 auditId) external view returns (Audit memory) {
        return audits[auditId];
    }
}