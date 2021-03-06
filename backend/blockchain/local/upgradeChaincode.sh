#!/bin/bash
set -ex
# LANGUAGE=${1:-"golang"}
VERSION=$1

# TODO, for some reason chaincode was not being updated even after tearing down network. Only resolution was to change name of chaincode from "food" to "asset"
echo "Copying Chaincode to cli container"
# docker cp ../chaincode cli:/opt/gopath/src/github.com/asset
docker cp /Users/kkbankol@us.ibm.com/projects/Blockchain-for-maintaining-Digital-Assets/contract/lib cli:/opt/gopath/src/github.com/asset
echo "Install and Instantiate Chaincode"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n asset -v $VERSION -p /opt/gopath/src/github.com/asset -l node
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode upgrade -l node -o orderer.example.com:7050 -C mychannel -n asset -v $VERSION -c '{"Args":[]}' -P 'OR ("Org1MSP.member")'

echo "Chaincode Upgraded"
sleep 10
echo "Test Chaincode"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n asset -c '{"Args":["queryAllDigitalAssets"]}'
