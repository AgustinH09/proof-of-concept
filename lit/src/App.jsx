import { useEffect, useState } from 'react';
import './App.css'
import * as LitJsSdk from '@lit-protocol/lit-node-client';

const litActionCode = `
const go = async () => {  
  // this requests a signature share from the Lit Node
  // the signature share will be automatically returned in the HTTP response from the node
  // all the params (toSign, publicKey, sigName) are passed in from the LitJsSdk.executeJs() function
  console.log("toSign: ", toSign)
  console.log("publicKey: ", publicKey)
  console.log("sigName: ", sigName)
  const sigShare = await Lit.Actions.signEcdsa({
    toSign,
    publicKey:
      "0x04754ad3e3a14ecfcb8ded94bf20ed0b4a23cd89f3505dd0db53fa8fa7d396ce7fdaae566875d6baafd6b8ff4d1705bab96421f3c4c38b25a9729937a45e59e5e6",
    sigName: "sig1",
  });
  console.log("sigShare: ", sigShare)
  return sigShare;
};

go();
`;

function App() {
  const [signatures, setSignatures] = useState({});
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    window.process = {
      ...window.process,
    };
  }, []);

  const runLitAction = async () => {
    // you need an AuthSig to auth with the nodes
    // this will get it from MetaMask or any browser wallet

    const authSig = await LitJsSdk.checkAndSignAuthMessage({ chain: "ethereum" });
    setLoading(true);
    const litNodeClient = new LitJsSdk.LitNodeClient({ litNetwork: "serrano" });
    await litNodeClient.connect();
    const sigs = await litNodeClient.executeJs({
      code: litActionCode,
      authSig,
      // all jsParams can be used anywhere in your litActionCode
      jsParams: {
        // this is the string "Hello World" for testing
        toSign: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100],
        publicKey:
          "0x04754ad3e3a14ecfcb8ded94bf20ed0b4a23cd89f3505dd0db53fa8fa7d396ce7fdaae566875d6baafd6b8ff4d1705bab96421f3c4c38b25a9729937a45e59e5e6",
        sigName: "sig1",
      },
    });
    setLoading(false);
    setSignatures([sigs.signatures]);
  };


  return (
    <>
      {loading && <div style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%", background: "rgba(0,0,0,0.5)", zIndex: 1000 }}></div>}
      <h1>Vite + React + Lit</h1>
      <div className="card">
        <button onClick={() => runLitAction()}>
          Run Lit Action
        </button>
          <pre style={{padding: 20, maxWidth: 500, margin: "0 auto", textWrap: "wrap", overflow: "auto" }}>
            {JSON.stringify(signatures)}
          </pre>
      </div>
    </>
  )
}

export default App
