import { toNano } from '@ton/core';
import { OnChainDataNFT } from '../wrappers/OnChainData';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const onChainData = provider.open(await OnChainDataNFT.fromInit());

    await onChainData.send(
        provider.sender(),
        {
            value: toNano('0.2'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(onChainData.address);

    // run methods on `onChainData`
}
