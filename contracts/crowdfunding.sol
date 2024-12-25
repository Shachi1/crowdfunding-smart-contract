// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    // Struct to hold project details
    struct Project {
        uint256 projectID;
        string projectTitle;
        string projectDescription;
        address projectOwner;
        uint256 projectParticipationAmount;
        uint256 projectTotalFundingAmount;
    }

    // Mapping to store all projects by projectID
    mapping(uint256 => Project) public projects;
    // Mapping to store user contributions by projectID and user address
    mapping(uint256 => mapping(address => uint256)) public userContributions;
    // Auto-increment projectID
    uint256 public projectCount;

    // Event for project creation
    event ProjectCreated(uint256 projectID, address projectOwner, string projectTitle);
    // Event for contribution
    event ContributionMade(uint256 projectID, address contributor, uint256 amount);
    // Event for fund withdrawal
    event FundsWithdrawn(uint256 projectID, address projectOwner, uint256 amount);

    // Function to create a new crowdfunding project
    function createProject(
        string memory _title, 
        string memory _description
    ) public {
        projectCount++;  // Increment the project count for unique projectID
        uint256 newProjectID = projectCount;

        projects[newProjectID] = Project({
            projectID: newProjectID,
            projectTitle: _title,
            projectDescription: _description,
            projectOwner: msg.sender,
            projectParticipationAmount: 0,
            projectTotalFundingAmount: 0
        });

        emit ProjectCreated(newProjectID, msg.sender, _title);
    }

    // Function to participate in a crowdfunding project
    function participateToProject(uint256 _projectID) public payable {
        require(msg.value > 0, "Contribution must be greater than 0");
        Project storage project = projects[_projectID];
        require(project.projectID != 0, "Project does not exist");

        project.projectParticipationAmount = msg.value;
        project.projectTotalFundingAmount += msg.value;
        userContributions[_projectID][msg.sender] += msg.value;

        emit ContributionMade(_projectID, msg.sender, msg.value);
    }

    // Function to retrieve project details
    function getProjectDetails(uint256 _projectID) public view returns (
        string memory title,
        string memory description,
        address owner,
        uint256 totalFundingAmount
    ) {
        Project storage project = projects[_projectID];
        require(project.projectID != 0, "Project does not exist");
        
        return (
            project.projectTitle,
            project.projectDescription,
            project.projectOwner,
            project.projectTotalFundingAmount
        );
    }

    // Function to retrieve contributions by a specific address for a specific project
    function retrieveContributions(uint256 _projectID, address _user) public view returns (uint256) {
        return userContributions[_projectID][_user];
    }

    // Function to withdraw funds for the project owner
    function withdrawFunds(uint256 _projectID) public {
        Project storage project = projects[_projectID];
        require(project.projectOwner == msg.sender, "Only project owner can withdraw funds");
        require(project.projectTotalFundingAmount > 0, "No funds to withdraw");

        uint256 amountToWithdraw = project.projectTotalFundingAmount;
        project.projectTotalFundingAmount = 0;

        payable(msg.sender).transfer(amountToWithdraw);
        emit FundsWithdrawn(_projectID, msg.sender, amountToWithdraw);
    }
}
