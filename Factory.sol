// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pair.sol";

/**
 * @title Factory
 * @dev Контракт для создания новых пулов ликвидности (пар) для торговых пар токенов.
 */
contract Factory {
    // Событие, которое генерируется при создании новой пары
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    // Маппинг для отслеживания адресов пар по двум токенам
    mapping(address => mapping(address => address)) public getPair;

    // Массив всех созданных пар
    address[] public allPairs;

    /**
     * @dev Функция для создания новой пары токенов.
     * @param tokenA Адрес первого токена.
     * @param tokenB Адрес второго токена.
     * @return pair Адрес созданной пары.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Factory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Factory: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "Factory: PAIR_EXISTS");

        // Создаем новый контракт Pair
        Pair newPair = new Pair(token0, token1);
        pair = address(newPair);

        // Сохраняем адрес пары в маппинге
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // Для симметрии

        // Добавляем пару в массив всех пар
        allPairs.push(pair);

        // Генерируем событие
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev Функция для получения количества всех созданных пар.
     * @return Количество пар.
     */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
}
