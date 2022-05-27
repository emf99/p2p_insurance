from brownie import accounts, Insurance, config, network

def deploy_insurance():
    # account=accounts[0]
    
    # print(insuranc) */
    account=get_account()
    insuranc=Insurance.deploy({"from": account})
    # print("bcc",account)

def main():
    deploy_insurance()
    
def get_account():
    if network.show_active() == "development":
        return accounts[0]
    else:
       return accounts.add(config["wallets"]["from_key"]) 
       
    