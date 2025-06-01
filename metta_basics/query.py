from hyperon import MeTTa

metta = MeTTa()
print(metta.run("!(+ 1 3)"))

with open("family.metta") as file:
    metta.run(file.read())
    output = metta.run("!(isSibiling Adam Monica)")
    parents = metta.run("!(unique ( match &self ($x isParentOf $y) $x))") # it will be only the unique just like set
    print(output)
    print(parents)
# /;
