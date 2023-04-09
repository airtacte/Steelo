pragma solidity ^0.8.19;

import "@openzeppelin\contracts\token\ERC1155\ERC1155.sol";

contract MyERC1155 is ERC1155 {
    constructor() ERC1155("https://myapi.com/api/token/{id}.json") {
        // Your custom constructor code here
    }

    // Your custom contract code here
}