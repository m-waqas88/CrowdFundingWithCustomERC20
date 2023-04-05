// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ICrowdFunding.sol";

contract CrowdFunding is ICrowdFunding, ERC20 {

    event ProjectCreated(uint _projectId);
    event FundsPledged(address _pledgor, uint _projectId, uint _amount);
    event RefundProcessed(uint _projectId, address _pledgor, uint _amount);
    event FundsWithdrawn(uint _projectId, uint _amount);

    uint private projectId;

    struct Project {
        string title;
        string description;
        uint goal;
        uint fundsRaised;
        uint timeline;
        bool completed;
    }

    constructor (uint _amount) ERC20(_amount) {
        projectId = 1;
    }

    mapping(uint => Project) public projects;
    mapping(uint => mapping(address => uint)) public contribution;

    function startProject(
        string memory _title, 
        string memory _description, 
        uint _goal,
        uint _duration
    ) 
    external onlyOwner
    {
        require(_goal > 0, "Pelase specify a goal");
        Project memory newProject;
        newProject.title = _title;
        newProject.description = _description;
        newProject.goal = _goal;
        newProject.timeline = block.timestamp + _duration;
        projects[projectId] = newProject;
        emit ProjectCreated(projectId);
        projectId ++;
    }

    function pledge(uint _projectId, uint _amount) external {
        require(_amount > 0, "Invalid amount");
        require(
            projects[_projectId].timeline >= block.timestamp,
            "Funding duration has lapsed"
        );
        require(
            projects[_projectId].goal != projects[_projectId].fundsRaised,
            "Funding completed"
        );
        projects[_projectId].fundsRaised += _amount;
        contribution[_projectId][msg.sender] = _amount;
        transfer(address(this), _amount);
        emit FundsPledged(msg.sender, _projectId, _amount);
    }
    function claimRefund(uint _projectId) external {
        uint amountPledged = contribution[_projectId][msg.sender];
        require(_projectId > 0 && _projectId < projectId, "Invalid Project ID");
        require(amountPledged > 0, "No amount pledged");
        require(
            projects[_projectId].fundsRaised < projects[_projectId].goal,
            "Funding Completed"
        );
        require(
            projects[_projectId].timeline < block.timestamp,
            "Funding still in process"
        );
        _transferTokens(address(this), msg.sender, amountPledged);
        emit RefundProcessed(_projectId, msg.sender, amountPledged);
    }
    function withdraw(uint _projectId) onlyOwner external {
        require(
            projects[_projectId].completed == false,
            "Funds for this project already withdrawn"
        );
        require(
            projects[_projectId].fundsRaised >= projects[_projectId].goal,
            "Not enough funds raised"
        );
        require(
            projects[_projectId].timeline < block.timestamp,
            "Funding still in process, cannot withdraw"
        );
        _transferTokens(address(this), owner, projects[_projectId].fundsRaised);
        projects[_projectId].completed = true;
        emit FundsWithdrawn(_projectId, projects[_projectId].fundsRaised);
    }

}