// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    uint256 private newProjectID = 0;

    // Mapping to store all projects by projectID
    mapping(uint256 => Project) public projects;
    // Mapping to store user address and contribution by projectID
    mapping(uint256 => Contribution[]) public userContributions;

    // Struct to hold project details
    struct Project {
        uint256 projectID;
        string projectTitle;
        string projectDescription;
        address projectOwner;
        uint256 projectParticipationAmount;
        uint256 projectTotalFundingAmount;
    }

    // Struct to hold contribution amount by address
    struct Contribution {
        address user;
        uint256 amount;
    }

    // Event for project creation
    event ProjectCreated(uint256 projectID, address projectOwner, string projectTitle);
    // Event for user contribution
    event ContributionMade(uint256 projectID, address contributor, uint256 amount);
    // Event for fund withdrawal
    event FundsWithdrawn(uint256 projectID, address projectOwner, uint256 amount);


    // Function to create a new crowdfunding project
    function createProject(
        string memory _title,
        string memory _description
    ) external {

        // Auto-increment projectID
        newProjectID++;

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
    function participateToProject(uint256 _projectID) external payable {
        require(_projectID > 0 && _projectID <= newProjectID, "Project does not exist");
        uint256 fund = msg.value;
        require(fund > 0, "Contribution must be greater than 0");
        Project storage project = projects[_projectID];

        for (uint256 i = 0; i < userContributions[_projectID].length; i++) {
            
            if (userContributions[_projectID][i].user == msg.sender) {
                // If the user contributed to this project before
                userContributions[_projectID][i].amount += fund;
                project.projectTotalFundingAmount += fund;
                emit ContributionMade(_projectID, msg.sender, fund);
                return;
            }
        }
        // If the user contributed for the first time to this project
        project.projectParticipationAmount += 1;
        project.projectTotalFundingAmount += fund;

        userContributions[_projectID].push(Contribution({
            user: msg.sender,
            amount: fund
        }));

        emit ContributionMade(_projectID, msg.sender, fund);
    }


    // Function to retrieve project details
    function getProjectDetails(uint256 _projectID) external view returns (
        string memory title,
        string memory description,
        address owner,
        uint256 projectParticipationAmount,
        uint256 totalFundingAmount
    ) {
        require(_projectID > 0 && _projectID <= newProjectID, "Project does not exist");
        Project storage project = projects[_projectID];
        
        return (
            project.projectTitle,
            project.projectDescription,
            project.projectOwner,
            project.projectParticipationAmount,
            project.projectTotalFundingAmount
        );
    }


    // Function to retrieve contributions by a specific address for a specific project
    function retrieveContributions(address _user, uint256 _projectID) external view returns (uint256) {
        require(_projectID > 0 && _projectID <= newProjectID, "Project does not exist");
        Contribution[] memory contributions = userContributions[_projectID];
        for (uint256 i = 0; i < contributions.length; i++) {
            if (contributions[i].user == _user) {
                return contributions[i].amount;
            }
        }
        return 0;
    }


    // Function to withdraw funds for the project owner
    function withdrawFunds(uint256 _projectID) external {
        Project storage project = projects[_projectID]; 
        require(project.projectOwner == msg.sender, "Only project owner can withdraw funds");
        require(project.projectTotalFundingAmount > 0, "No funds to withdraw");

        uint256 amountToWithdraw = project.projectTotalFundingAmount;
        project.projectTotalFundingAmount = 0;

        payable(msg.sender).transfer(amountToWithdraw);
        emit FundsWithdrawn(_projectID, msg.sender, amountToWithdraw);
    }
}