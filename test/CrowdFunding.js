const { expect }  = require("chai");
const { ethers, network } = require("hardhat");

describe("Crowdfunding overall functionality testing", async() => {

  let contract, accounts, owner, project, pledgorWallet, contractBalance, pledgorBalance, ownerBalance;

  before(async() => {
    accounts = await ethers.getSigners();
    owner = accounts[0];
    const Contract = await ethers.getContractFactory("CrowdFunding");
    contract = await Contract.deploy(1000000);
    await contract.deployed();
    console.log(`Contract deployed at: ${contract.address}`);
  });

  it("Project owners can create a new crowd funding project", async() => {
    const wallet = await contract.connect(owner);
    const title = "Project1";
    const description = "Description of project1";
    const goal = 2000;
    const duration = 300; // seconds
    await wallet.startProject(title, description, goal, duration);
    project = await wallet.projects(1);
    expect(project.title).to.equal("Project1");
  });

  it("Every new crowdfunded project has a timeline and a funding goal", async() => {
    console.log(`Project Timeline: ${project.timeline}`);
    expect(project.goal).to.equal(2000);
  });
  
  it("Users can fund different projects within the timeline", async() => {
    const wallet = await contract.connect(owner);
    await wallet.transfer(accounts[1].address, 5000);
    pledgorWallet = await contract.connect(accounts[1]);
    await pledgorWallet.pledge(1,2000);
    contractBalance = await contract.balanceOf(contract.address);
    pledgorBalance = await contract.balanceOf(accounts[1].address);
    expect(contractBalance).to.equal(2000);
    expect(pledgorBalance).to.equal(3000);
  });

  it("Owner can withdraw funds after successful project completion", async() => {
    const wallet = await contract.connect(owner);
    await network.provider.send("evm_increaseTime", [3500]);
    await wallet.withdraw(1);
    contractBalance = await contract.balanceOf(contract.address);
    ownerBalance = await contract.balanceOf(owner.address);
    expect(contractBalance).to.equal(0);
    expect(ownerBalance).to.equal(997000);
  });

  it("If the funds are not successfully raised by the time the campaign ends, users should be able to withdraw their funds", async() => {
    const wallet = await contract.connect(owner);
    const title = "Project2";
    const description = "Description of project2";
    const goal = 5000;
    const duration = 240; // seconds
    await wallet.startProject(title, description, goal, duration);
    await pledgorWallet.pledge(2,2000);
    await network.provider.send("evm_increaseTime", [250]);
    await pledgorWallet.claimRefund(2);
    expect(contractBalance).to.equals(0);
    expect(pledgorBalance).to.equals(3000);
  });

});