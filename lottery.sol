// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Lottery {
    address public manager;
    address payable[] public participants;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(
            msg.value == 2 ether,
            "Please send exactly 2 ether to participate in the lottery"
        );
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns (uint256) {
        require(
            msg.sender == manager,
            "Only the manager can check the contract balance"
        );
        return address(this).balance;
    }

    // Generate random number
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        participants.length
                    )
                )
            );
    }

    function selectWinner() public returns (address) {
        require(msg.sender == manager, "Only the manager can select the winner");
        require(participants.length >= 3, "At least 3 participants are required to select a winner");

        uint r = random();
        uint i = r % participants.length;
        address payable winner = participants[i];
        winner.transfer(getBalance());

        // Reset the participants array for the next round
        delete participants;
        return winner;
    }
}
