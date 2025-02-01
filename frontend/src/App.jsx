import React from 'react';
import { createWeb3Modal } from '@web3modal/wagmi/react';
import { defaultWagmiConfig } from '@web3modal/wagmi/react/config';
import { WagmiProvider } from 'wagmi';
import { 
  mainnet, sepolia, baseSepolia, base, optimism, arbitrum, polygon, polygonMumbai 
} from 'wagmi/chains';
import { 
  useAccount, useDisconnect, useBalance,useChainId,useSwitchChain
} from 'wagmi';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// Project ID from https://cloud.walletconnect.com/
const projectId = import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID;

// Configure wagmi config with multiple chains
const metadata = {
  name: 'Web3 Sample dApp',
  description: 'Web3 Wallet Connection Demo',
  url: 'https://yourapp.com',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
};

const chains = [
  mainnet, sepolia, baseSepolia, base, optimism, arbitrum, polygon, polygonMumbai
];

const config = defaultWagmiConfig({
  chains, projectId, metadata,
});

// Create modal
createWeb3Modal({
  wagmiConfig: config,
  projectId,
  enableAnalytics: true,
  themeMode: 'light'
});

// Query client for React Query
const queryClient = new QueryClient();

function WalletConnection() {
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const chainId = useChainId();
  const { switchChain } = useSwitchChain();
  const { data: balance } = useBalance({ address });

  // Get current chain name
  const getCurrentChainName = () => {
    const currentChain = chains.find(chain => chain.id === chainId);
    return currentChain ? currentChain.name : 'Unknown Network';
  };

  return (
    <div className="p-4 max-w-md mx-auto">
      <h1 className="text-2xl font-bold mb-4">Web3 Sample dApp</h1>
      
      {!isConnected ? (
        <w3m-button />
      ) : (
        <div>
          <div className="bg-gray-100 p-4 rounded-lg mb-4">
            <p className="font-semibold">Connected Address:</p>
            <p className="break-words">{address}</p>
            <p className="mt-2">Network: {getCurrentChainName()}</p>
          </div>

          <div className="network-selector mb-4">
            <h2 className="font-bold mb-2">Available Networks</h2>
            <div className="grid grid-cols-2 gap-2">
              {chains.map((chain) => (
                <button
                  key={chain.id}
                  onClick={() => switchChain({ chainId: chain.id })}
                  className={`p-2 rounded text-sm ${
                    chainId === chain.id
                      ? 'bg-blue-500 text-white'
                      : 'bg-gray-200 hover:bg-gray-300'
                  }`}
                >
                  {chain.name}
                </button>
              ))}
            </div>
          </div>

          {balance && (
            <div className="bg-gray-100 p-4 rounded-lg mb-4">
              <p>Balance: {balance.formatted} {balance.symbol}</p>
            </div>
          )}

          <button 
            onClick={() => disconnect()}
            className="bg-red-500 text-white px-4 py-2 rounded"
          >
            Disconnect
          </button>
        </div>
      )}
    </div>
  );
}

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <WalletConnection />
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
