// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/diamond/Diamond.sol";
import "@openzeppelin/contracts-upgradeable/proxy/diamond/DiamondCutFacet.sol";
import "@openzeppelin/contracts-upgradeable/proxy/diamond/DiamondLoupeFacet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract SteeloDiamond is Diamond, OwnableUpgradeable {
    function initialize(address _owner) public initializer {
        // Initialize the Diamond contract
        Diamond.initialize();

        // Initialize the Ownable contract
        OwnableUpgradeable.initialize(_owner);

        // Add the DiamondCutFacet
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        bytes[] memory cut = new bytes[](2);
        cut[0] = abi.encodePacked(diamondCutFacet, DiamondCutFacet.cut.selector);
        cut[1] = abi.encodePacked(diamondLoupeFacet, DiamondLoupeFacet.loupe.selector);
        diamondCut(cut);
    }
}