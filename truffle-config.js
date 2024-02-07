module.exports = {
    networks: {
        // your network configuration
    },
    compilers: {
        solc: {
            version: "0.8.19", // replace with your desired Solidity version
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    }
};