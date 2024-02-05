// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/LibDiamond.sol";

contract SteezAccessControlFacet {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.contractOwner = msg.sender;
    }

    // ACCESS CONTROL 

        // Add/Remove Admin Role
        function addAdmin(address _admin) external onlyOwner {admins[_admin] = true;}
        function removeAdmin(address _admin) external onlyOwner {admins[_admin] = false;}

        // Add/Remove Creator Role
        function addCreator(address _creator) external onlyAdmin {creators[_creator] = true;}
        function removeCreator(address _creator) external onlyAdmin {creators[_creator] = false;}

        // Add/Remove Owner Role
        function addOwner(address _owner) external onlyCreator {owners[_owner] = true;}
        function removeOwner(address _owner) external onlyCreator {owners[_owner] = false;}

        // Add/Remove User Role
        function addUser(address _user) external onlyOwnerOrAdmin {users[_user] = true;}
        function removeUser(address _user) external onlyOwnerOrAdmin {users[_user] = false;}

        // Function to restrict feature access to a role
        function isAdmin(address _admin) external view returns(bool) {return admins[_admin];}
        function isCreator(address _creator) external view returns(bool) {return creators[_creator];}
        function isOwner(address _owner) external view returns(bool) {return owners[_owner];}
        function isUser(address _user) external view returns(bool) {return users[_user];}


        // Remove token holder
        function _removeTokenHolder(uint256 tokenId, address holder) internal {
            uint256 len = _tokenHolders[tokenId].length;
            for (uint256 i = 0; i < len; i++) {
                if (_tokenHolders[tokenId][i] == holder) {
                    _tokenHolders[tokenId][i] = _tokenHolders[tokenId][len - 1];
                    _tokenHolders[tokenId].pop();
                    break;
                }
            }
        }

        // Get token holders
        function getTokenHolders(uint256 tokenId) public view returns (address[] memory) {
            return _tokenHolders[tokenId];
        }

        // Add token holder
        function _addTokenHolder(uint256 tokenId, address holder) internal {
            _tokenHolders[tokenId].push(holder);
        }
