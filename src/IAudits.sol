// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAudits {
    /*//////////////////////////////////////////////////////////////////////////
                                         STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Audit {
        address client;
        address token;
        uint256 amount;
        uint256 amountPerPhase;
        uint256 totalPhases;
        uint256 currentPhase;
        bool confirmed;
        bool finished;
    }

    struct Phase {
        bool submitted;
        bool confirmed;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function proposeAudit(address client, address token, uint256 amount, uint256 totalPhases)
        external
        returns (uint256);
    function approveAudit(uint256 auditId) external;
    function cancelAudit(uint256 auditId) external;
    function submitPhase(uint256 auditId) external;
    function approvePhase(uint256 auditId) external;

    function getAudit(uint256 auditId) external view returns (Audit memory);
    function setMaxPhases(uint256 maxPhases) external;

    /*//////////////////////////////////////////////////////////////////////////
                                         ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    error AddressZero();
    error ZeroAmount();
    error ExceededMaxPhases();
    error AuditInvalidClient();
    error AuditAlreadyConfirmed();
    error AuditNotYetConfirmed();
    error AuditAlreadyFinished();
    error PhaseAlreadyConfirmed();
    error PhaseAlreadySubmitted();
    error PhaseNotYetSubmitted();
}
