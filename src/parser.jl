Term(str::AbstractString) = begin
    function get_term(str)
        function_match = match(r"(\w*)\((.*)\)$", str)
        if function_match == nothing
            Variable(strip(str))
        else
            name = strip(function_match.captures[1])
            arguments = get_term.(argumentsplit(strip(function_match.captures[2])))
            Function(FunctionSymbol(name), arguments)
        end
    end
    get_term(str)
end

AtomicFormula(str::AbstractString) = begin
    formula = strip_and_remove_surrounding_brackets(str)
    atomic_formula_match = match(r"(\w*)\((.*)\)$", formula)
    name = strip(atomic_formula_match.captures[1])
    arguments = Term.(argumentsplit(strip(atomic_formula_match.captures[2])))
    AtomicFormula(PredicateSymbol(name), arguments)
end

Negation(str::AbstractString) = begin
    Negation(Formula(str[2:end]))
end

EFormula(str::AbstractString) = begin
    e_formula_match = match(r"\?\{(\w+)\}(.*)", str)
    name = strip(e_formula_match.captures[1])
    formula = strip(e_formula_match.captures[2])
    EFormula(Variable(name), Formula(formula))
end

AFormula(str::AbstractString) = begin
    a_formula_match = match(r"\*\{(\w+)\}(.*)", str)
    name = strip(a_formula_match.captures[1])
    formula = strip(a_formula_match.captures[2])
    AFormula(Variable(name), Formula(formula))
end

Formula(str::AbstractString) = begin
    formula = strip_and_remove_surrounding_brackets(str)
    parts = strip.(bracketsplit(formula))
    previous_junction = 0
    current_junction = findfirst(part->ismatch(r"^[&|]$", part), parts)
    if current_junction == 0
        @match formula[1] begin
        '?' => return EFormula(formula)
        '*' => return AFormula(formula)
        '~' => return Negation(formula)
        _ => return AtomicFormula(formula)
        end
    else
        formula1 = strip(join(parts[previous_junction+1:current_junction-1]))
        operator = strip(join(parts[current_junction]))
        formula2 = strip(join(parts[current_junction+1:end]))
        @match operator begin
        "&" => return Conjunction(Formula(join(formula1)), Formula(formula2))
        "|" => return Disjunction(Formula(formula1), Formula(formula2))
        end
    end
end
