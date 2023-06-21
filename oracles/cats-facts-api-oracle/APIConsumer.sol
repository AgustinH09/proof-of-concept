// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    string public fact;
    bytes32 private jobId;
    uint256 private fee;

    event RequestFact(bytes32 indexed requestId, string fact);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Sepolia Testnet details:
     * Link Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestVolumeData(uint256 factNumber) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        req.add(
            "get",
            "https://cat-fact.herokuapp.com/facts"
        );
        req.add("path", "0,text");

        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        string memory _fact
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestFact(_requestId, _fact);
        fact = _fact;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
