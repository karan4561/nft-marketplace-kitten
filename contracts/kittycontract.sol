// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract kittycontract is IERC721,Ownable {

    string public constant name = "karanKitties";
    string public constant symbol = "KK";

    event Birth(
        address owner,
        uint256 kittenId,
        uint256 momId,
        uint256 dadId,
        uint256 genes
    );

    struct kitty {
        uint256 genes;
        uint birthTime;
        uint momId;
        uint dadId;
        uint generation;
    }

    kitty[] kitties;

    mapping(uint256=>address) public kittyIndexToOwner;
    mapping(address=>uint256) ownershipTokenCount;
    mapping(uint256=>address) public indexToApproved;
    mapping(address=>mapping(address=>bool)) private _operatorApprovals;

    uint256 public gen0counter;

    function createKittyGen0(uint256 _genes) public onlyOwner returns(uint256){

        return _createKitty(0, 0, 0, _genes, msg.sender);

    }


    function _createKitty(
        uint256 _mumId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint256){

        kitty memory _kitty = kitty({
            genes: _genes,
            birthTime: uint256(block.timestamp),
            momId: uint32(_mumId),
            dadId: uint32(_dadId),
            generation: _generation
        });

        kitties.push(_kitty);

        uint256 newcatId = kitties.length-1;

        emit Birth(_owner,newcatId,_mumId,_dadId,_genes);

        _transfer(address(0), _owner , newcatId);

        return newcatId;
    }

    function getKitty(uint256 index) external view returns(kitty memory){
        return kitties[index];
    }



    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance){
        return ownershipTokenCount[owner];
    }

    /*
     * @dev Returns the total number of tokens in circulation.
     */
    function totalSupply() external view returns (uint256 total){
        
        return kitties.length;
    }

    /*
     * @dev Returns the name of the token.
     */
    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner){
        return kittyIndexToOwner[tokenId];
    }


     /* @dev Transfers `tokenId` token from `msg.sender` to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `to` can not be the contract address.
     * - `tokenId` token must be owned by `msg.sender`.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 tokenId) external{
        require(to!=address(0));
        require(to!=address(this));
        require(_owns(msg.sender,tokenId));

        _transfer(msg.sender,to,tokenId);
    }


    function _transfer(address _from, address _to, uint256 _tokenId) internal{
        kittyIndexToOwner[_tokenId]=_to;

        ownershipTokenCount[_to]++;

        if(_from!=address(0)){
            ownershipTokenCount[_from]--;
            delete indexToApproved[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);
    }

    function _owns(address check, uint256 _tokenId) internal view returns(bool){
        return kittyIndexToOwner[_tokenId]==check;
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external{
        require(_owns(msg.sender,_tokenId));
        if(_approved != address(0)){
            indexToApproved[_tokenId]=_approved;
        }
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external{
       
       require(msg.sender!=_operator);
       
        _operatorApprovals[msg.sender][_operator]=_approved;
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address){
        return indexToApproved[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }




}