import { SafeFactory } from "@safe-global/safe-core-sdk";

async function createSafe(owners, threshold, provider) {
  const safeFactory = new SafeFactory(provider);
  const safe = await safeFactory.createSafe({
    owners,
    threshold,
  });

  console.log("Safe address:", safe.getAddress());
  return safe;
}

export { createSafe };