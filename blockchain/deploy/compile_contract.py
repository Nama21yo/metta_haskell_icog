from vyper import compile_code
import json

with open('../contracts/basix_marketplace.vy', 'r') as file:
    contract_source = file.read()

compiled = compile_code(contract_source, output_formats=['abi', 'bytecode'])

with open('compiled_contract.json', 'w') as f:
    json.dump({
        'abi': compiled['abi'],
        'bytecode': compiled['bytecode']
    }, f, indent=2)

print("Contract compiled successfully!")
