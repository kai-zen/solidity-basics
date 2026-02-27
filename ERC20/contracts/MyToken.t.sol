// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {MyToken} from "./MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;

    address owner = address(this);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    uint256 constant INITIAL_SUPPLY = 1_000_000 * 1e18;

    // ─── Event declarations (needed for vm.expectEmit)
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // ─── Setup
    function setUp() public {
        token = new MyToken("My Token", "MTK", 18, INITIAL_SUPPLY);
    }

    // ─── Deployment
    function test_Name() public view {
        assertEq(token.name(), "My Token");
    }

    function test_Symbol() public view {
        assertEq(token.symbol(), "MTK");
    }

    function test_Decimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_TotalSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_OwnerBalanceOnDeploy() public view {
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    // ─── Transfer
    function test_Transfer() public {
        uint256 amount = 500 * 1e18;
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferEmitsEvent() public {
        uint256 amount = 100 * 1e18;
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, alice, amount);
        token.transfer(alice, amount);
    }

    function test_RevertWhen_TransferInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert("ERC20: insufficient balance");
        token.transfer(bob, 1);
    }

    function test_RevertWhen_TransferToZeroAddress() public {
        vm.expectRevert("ERC20: transfer to zero address");
        token.transfer(address(0), 1);
    }

    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    // ─── Approve / Allowance
    function test_Approve() public {
        uint256 amount = 1000 * 1e18;
        token.approve(alice, amount);

        assertEq(token.allowance(owner, alice), amount);
    }

    function test_ApproveEmitsEvent() public {
        uint256 amount = 1000 * 1e18;
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, alice, amount);
        token.approve(alice, amount);
    }

    function test_ApproveOverwritesPreviousAllowance() public {
        token.approve(alice, 1000 * 1e18);
        token.approve(alice, 500 * 1e18);

        assertEq(token.allowance(owner, alice), 500 * 1e18);
    }

    // ─── TransferFrom
    function test_TransferFrom() public {
        uint256 amount = 300 * 1e18;
        token.approve(alice, amount);

        vm.prank(alice);
        token.transferFrom(owner, bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.allowance(owner, alice), 0);
    }

    function test_TransferFrom_ReducesAllowance() public {
        uint256 approved = 1000 * 1e18;
        uint256 spent = 400 * 1e18;
        token.approve(alice, approved);

        vm.prank(alice);
        token.transferFrom(owner, bob, spent);

        assertEq(token.allowance(owner, alice), approved - spent);
    }

    function test_RevertWhen_TransferFromInsufficientAllowance() public {
        token.approve(alice, 100 * 1e18);
        vm.prank(alice);
        vm.expectRevert("ERC20: insufficient allowance");
        token.transferFrom(owner, bob, 200 * 1e18);
    }

    function test_RevertWhen_TransferFromInsufficientBalance() public {
        vm.prank(owner);
        token.transfer(alice, 100 * 1e18);

        token.approve(charlie, INITIAL_SUPPLY);

        vm.prank(charlie);
        vm.expectRevert("ERC20: insufficient balance");

        // owner now only has INITIAL_SUPPLY - 100e18, try to spend full supply
        token.transferFrom(owner, bob, INITIAL_SUPPLY);
    }

    function testFuzz_TransferFrom(uint256 approved, uint256 spent) public {
        approved = bound(approved, 0, INITIAL_SUPPLY);
        spent = bound(spent, 0, approved);

        token.approve(alice, approved);

        vm.prank(alice);
        token.transferFrom(owner, bob, spent);

        assertEq(token.balanceOf(bob), spent);
        assertEq(token.allowance(owner, alice), approved - spent);
    }

    // ─── Mint
    function test_Mint() public {
        uint256 amount = 500 * 1e18;
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function test_MintEmitsTransferFromZero() public {
        uint256 amount = 100 * 1e18;
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), alice, amount);
        token.mint(alice, amount);
    }

    function test_RevertWhen_MintNotOwner() public {
        vm.prank(alice);
        vm.expectRevert("not owner");
        token.mint(alice, 1);
    }

    function testFuzz_Mint(uint256 amount) public {
        amount = bound(amount, 0, type(uint128).max); // avoid overflow
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    // ─── Burn
    function test_Burn() public {
        uint256 amount = 200 * 1e18;
        token.burn(amount);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - amount);
    }

    function test_BurnEmitsTransferToZero() public {
        uint256 amount = 100 * 1e18;
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, address(0), amount);
        token.burn(amount);
    }

    function test_RevertWhen_BurnExceedsBalance() public {
        vm.prank(alice);
        vm.expectRevert("ERC20: burn exceeds balance");
        token.burn(1);
    }

    function testFuzz_Burn(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        token.burn(amount);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - amount);
    }
}
