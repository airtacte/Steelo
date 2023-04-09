//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; 

contract SteeloToken is ERC1155 {
    constructor() ERC1155("https://myapi.com/api/token/{id}.json") {
        // Your custom constructor code here
    }

    // Your custom contract code here
}