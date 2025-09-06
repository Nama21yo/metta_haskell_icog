from hyperon import *
import hyperonpy as hp
from hyperonpy import AtomKind, SerialResult, Serializer
import os
import glob

metta = MeTTa()
metta.run(f"!(bind! &space (new-space))")

def load_dataset(path: str) -> None:
    if not os.path.exists(path):
        raise ValueError(f"Dataset path '{path}' does not exist.")
    paths = glob.glob(os.path.join(path, "**/*.metta"), recursive=True)
    if not paths:
        raise ValueError(f"No .metta files found in dataset path '{path}'.")
    for path in paths:
        print(f"Start loading dataset from '{path}'...")
        try:
            metta.run(f'''
                !(load-ascii &space {path})
                ''')
        except Exception as e:
            print(f"Error loading dataset from '{path}': {e}")
    print(f"Finished loading {len(paths)} datasets.")

# Example usage:
try:
    dataset = load_dataset("./Data")
   
except Exception as e:
    print(f"An error occurred: {e}")

# 2 Points
def get_transcript(node):
    # print("My node", node, node[0])
     #TODO Implement the logic to fetch the transcript

     
    transcripter = f"!(collapse (match &space (transcribed_to  ({node[0]}) (transcript $result)) (transcribed_to ({node[0]}) (transcript $result))))"
    # print(transcripter)
    transcript = metta.run(transcripter)
    return transcript     

#2 Points
def get_protein(node):
    #TODO Implement the logic to fetch the protein
    # print("protein". node[0])
    
    # transcripter = f"!(let $transcript (match &space (transcribed_to  ({node[0]}) (transcript $result)) (transcribed_to {node[0]} (transcript $result)))  (match &space (translates_to (transcript $result) (protein $myprotein))))"
    transcripter = f"!(collapse (let $transcript (match &space (transcribed_to  ({node[0]}) (transcript $result)) $result)  (match &space (translates_to (transcript $transcript) (protein $myprotein)) (translates_to (transcript $transcript) (protein $myprotein)))))"
    # print(transcripter)
    protein = metta.run(transcripter) 
    return protein

#6 Points
def metta_seralizer(metta_result):
    # parser = f"""
    #             (= (mettaParser {metta_result})
    #                 (let*
    #                     (
    #                         ($each (superpose $input))
    #                         (($head $tail) (decons-atom $each))
    #                         (($gene $rest) (decons-atom $tail))
    #                     )
    #                     (
    #                         {"edge" : $head , "source" : $gene , "target" : $rest }
    #                     )
    #                 )
    #             )
    #             """
    # result = metta.run(parser)
    # print(metta_result)
    # answer = []
    # print("Each",metta_result[0] , metta_result[0][0])
    final_answer = []
    for expr in metta_result[0][0].get_children():
        # print("Expr" , expr)
        answer = []
        for each in expr.get_children():
            # print("Each expr", each)
            # print("getstring", str(each), type(each))
            myytype = each.get_metatype()
            AtomToString = []
            if myytype == AtomKind.EXPR:
                for atom in each.get_children():
                    # print("Each atom", atom)
                    # print("To string", atom.get_name())
                    AtomToString.append(atom.get_name())
                # print("Expression Atom", each)
            answer.append(" ".join(AtomToString))
            if myytype == AtomKind.SYMBOL:
                answer.append(each)
        # for each_el in answer[1:]:
        json = {"edge" : answer[1], "gene" : answer[2], "target" : answer[3]}
        final_answer.append(json)
        
        # print("My answer", answer)
        # each_Expression = metta.parse_single(expr)
        # print("Each Expr", each_Expression)
    # for atom in each_Expression.get_children():
        # print(f'type({atom})={type(atom)} atom {atom}')
    #TODO Implement logic to convert the Metta output into a structured format  (e.g., a list of dictionaries) that can be easily serialized to JSON.
    return final_answer



#1
transcript_result= (get_transcript(['gene ENSG00000166913']))
print(transcript_result) 
"""
Expected Output Format::
# [[(, (transcribed_to (gene ENSG00000166913) (transcript ENST00000372839))), (, (transcribed_to (gene ENSG00000166913) (transcript ENST00000353703)))]]
""" 
# 
# 2
protein_result= (get_protein(['gene ENSG00000166913']))
print(protein_result) 
"""
Expected Output Format::
# [[(, (translates_to (transcript ENST00000353703) (protein P31946))), (, (translates_to (transcript ENST00000372839) (protein P31946)))]]
"""

#3
parsed_result = metta_seralizer(transcript_result)
print(parsed_result) 
"""
Expected Output Format:
[
    {'edge': 'transcribed_to', 'source': 'gene ENSG00000175793', 'target': 'transcript ENST00000339276'}
]
"""

