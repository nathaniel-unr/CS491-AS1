# Name: Nathaniel Daniel
# Email: nathanieldaniel@nevada.unr.edu

import json

PATH = '18-ply.json'#'20-ply.json' #'15-ply.json'
OUT_PATH = 'generated.json'

def decode_state(state):
    return list(int(state).to_bytes(16, 'big'))
    
def encode_state(state):
    return str(int.from_bytes(state, 16, 'big'))

data = None
with open(PATH) as f:
    data = json.load(f)
  
with open(OUT_PATH, 'w') as f: 
    exp = {}
    
    for (k_raw, v) in data.items():
        k = decode_state(k_raw)
        
        best = None
        best_depth = 100
        for child in v['children']:
            child_v = data.get(child)
            
            if child_v is not None and child_v['depth'] < best_depth:
                best = child
                best_depth = child_v['depth']
                
        if best:
            k = ','.join(str(k) for k in reversed(k))
            v = ','.join(str(v) for v in reversed(decode_state(best)))
            exp[k] = v
            
    json.dump(exp, f)