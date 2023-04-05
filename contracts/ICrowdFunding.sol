// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICrowdFunding {
    function startProject(string memory _title, string memory _description, uint _goal, uint _duration) external;
    function pledge(uint _projectId, uint _amount) external;
    function claimRefund(uint _projectId) external;
    function withdraw(uint _projectId) external;
}