// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Token
 * @dev ERC-20 токен с базовыми функциями.
 */
contract Token is ERC20, Ownable {
    /**
     * @dev Конструктор контракта.
     * @param name Имя токена.
     * @param symbol Символ токена.
     * @param totalSupply Общее количество токенов.
     */
    constructor(string memory name, string memory symbol, uint256 totalSupply) ERC20(name, symbol) {
        _mint(msg.sender, totalSupply);
    }

    /**
     * @dev Функция для минтинга новых токенов.
     * @param account Адрес, на который будут зачислены токены.
     * @param amount Количество токенов.
     */
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    /**
     * @dev Функция для сжигания токенов.
     * @param amount Количество токенов для сжигания.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
