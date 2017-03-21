var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Matching.jl-1",
    "page": "Home",
    "title": "Matching.jl",
    "category": "section",
    "text": "Matching algorithms in Julia."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "This is an unregistered package. To install, open a Julia session and typePkg.clone(\"https://github.com/oyamad/Matching.jl\")"
},

{
    "location": "index.html#Usage-1",
    "page": "Home",
    "title": "Usage",
    "category": "section",
    "text": "After installation, you can use this package byusing Matching"
},

{
    "location": "api/Matching.html#",
    "page": "Matching",
    "title": "Matching",
    "category": "page",
    "text": ""
},

{
    "location": "api/Matching.html#Matching-1",
    "page": "Matching",
    "title": "Matching",
    "category": "section",
    "text": "CurrentModule = Matching\nDocTestSetup  = quote\n    using Matching\nend"
},

{
    "location": "api/Matching.html#Matching.deferred_acceptance",
    "page": "Matching",
    "title": "Matching.deferred_acceptance",
    "category": "Function",
    "text": "deferred_acceptance(s_prefs, c_prefs, caps[, proposal])\n\nCompute a stable matching by the DA algorithm for a many-to-one matching (college admission) problem.\n\nArguments\n\ns_prefs::Matrix{Int} : Array of shape (n+1, m) containing the students' preference orders as columns, where m is the number of students and n is that of the colleges. s_prefs[j, i] is the j-th preferred college for the i-th studnet, where \"college 0\" represents \"being single\".\nc_prefs::Matrix{Int} : Array of shape (m+1, n) containing the colleges' preference orders as columns. c_prefs[i, j] is the i-th preferred student for the j-th college, where \"student 0\" represents \"vacancy\".\ncaps::Vector{Int} : Vector of length n containing the colleges' capacities.\nproposal::Type(SProposing) : SProposing runs the student-proposing DA algorithm, while CProposing runs the college-proposing algorithm. Default to the former.\n\nReturns\n\ns_matches::Vector{Int} : Vector of length m representing the matches for the students, where s_matches[i] is the college that proposer i is matched with.\nc_matches::Vector{Int} : Vector of length n representing the matches for the colleges, where the students who college j is matched with are contained in c_matches[indptr[j]:indptr[j+1]-1].\nindptr::Vector{Int} : Contains index pointers for c_matches.\n\n\n\n"
},

{
    "location": "api/Matching.html#Matching.deferred_acceptance-Tuple{Array{Int64,2},Array{Int64,2},Array{Int64,1},Array{Int64,1}}",
    "page": "Matching",
    "title": "Matching.deferred_acceptance",
    "category": "Method",
    "text": "deferred_acceptance(prop_prefs, resp_prefs, prop_caps, resp_caps)\n\nCompute a stable matching by the DA algorithm for a many-to-many matching problem.\n\nArguments\n\nprop_prefs::Matrix{Int} : Array of shape (n+1, m) containing the proposers' preference orders as columns, where m is the number of proposers and n is that of the responders. prop_prefs[j, i] is the j-th preferred responder for the i-th proposer, where \"responder 0\" represents \"vacancy\".\nresp_prefs::Matrix{Int} : Array of shape (m+1, n) containing the responders' preference orders as columns. resp_prefs[i, j] is the i-th preferred proposer for the j-th responder, where \"proposer 0\" epresents \"vacancy\".\nprop_caps::Vector{Int} : Vector of length n containing the proposers' capacities.\nresp_caps::Vector{Int} : Vector of length n containing the responders' capacities.\n\nReturns\n\nprop_matches::Vector{Int} : Vector of length m representing the matches for the proposers, where the responders who proposer i is matched with are contained in prop_matches[prop_indptr[i]:prop_indptr[i+1]-1].\nresp_matches::Vector{Int} : Vector of length n representing the matches for the responders, where the proposers who responder j is matched with are contained in resp_matches[resp_indptr[j]:resp_indptr[j+1]-1].\nprop_indptr::Vector{Int} : Contains index pointers for prop_matches.\nresp_indptr::Vector{Int} : Contains index pointers for resp_matches.\n\n\n\n"
},

{
    "location": "api/Matching.html#Matching.deferred_acceptance-Tuple{Array{Int64,2},Array{Int64,2}}",
    "page": "Matching",
    "title": "Matching.deferred_acceptance",
    "category": "Method",
    "text": "deferred_acceptance(prop_prefs, resp_prefs)\n\nCompute a stable matching by the DA algorithm for a one-to-one matching (marriage) problem.\n\nArguments\n\nprop_prefs::Matrix{Int} : Array of shape (n+1, m) containing the proposers' preference orders as columns, where m is the number of proposers and n is that of the responders. prop_prefs[j, i] is the j-th preferred responder for the i-th proposer, where \"responder 0\" represents \"being-single\".\nresp_prefs::Matrix{Int} : Array of shape (m+1, n) containing the responders' preference orders as columns. resp_prefs[i, j] is the i-th preferred proposer for the j-th responder, where \"proposer 0\" represents \"being-single\".\n\nReturns\n\nprop_matches::Vector{Int} : Vector of length m representing the matches for the proposers, where prop_matches[i] is the responder who proposer i is matched with.\nresp_matches::Vector{Int} : Vector of length n representing the matches for the responders, where resp_matches[j] is the proposer who responder j is matched with.\n\n\n\n"
},

{
    "location": "api/Matching.html#Matching.random_prefs-Tuple{AbstractRNG,Integer,Integer}",
    "page": "Matching",
    "title": "Matching.random_prefs",
    "category": "Method",
    "text": "random_prefs([rng, ]m, n[, ReturnCaps]; allow_unmatched=true)\n\nGenerate random preference order lists for two groups, say, m males and n females.\n\nEach male has a preference order over femals [1, ..., n] and \"unmatched\" which is represented by 0, while each female has a preference order over males [1, ..., m] and \"unmatched\" which is again represented by 0.\n\nThe argument ReturnCaps should be supplied in the context of college admissions, in which case \"males\" and \"females\" should be read as \"students\" and \"colleges\", respectively, where each college has its capacity.\n\nThe optional rng argument specifies a random number generator.\n\nArguments\n\nm::Integer : Number of males.\nn::Integer : Number of females.\n::Type{ReturnCaps} : If supplied, caps is also returned.\n;allow_unmatched::Bool(true) : If false, return preference order lists of males and females where 0 is always placed in the last place, (i.e., \"unmatched\" is least preferred by every individual).\n\nReturns\n\nm_prefs::Matrix{Int} :  Array of shape (n+1, m), where each column contains a random permutation of 0, 1, ..., n.\nf_prefs::Matrix{Int} :  Array of shape (m+1, n), where each column contains a random permutation of 0, 1, ..., m.\ncaps::Vector{Int} : Vector of length n containing each female's (or college's) capacity. Returned only when ReturnCaps is supplied.\n\nExamples\n\njulia> m_prefs, f_prefs = random_prefs(4, 3);\n\njulia> m_prefs\n4x4 Array{Int64,2}:\n 3  3  1  3\n 0  2  3  1\n 2  1  2  0\n 1  0  0  2\n\njulia> f_prefs\n5x3 Array{Int64,2}:\n 1  2  4\n 4  3  1\n 3  4  2\n 0  0  0\n 2  1  3\n\njulia> m_prefs, f_prefs = random_prefs(4, 3, allow_unmatched=false);\n\njulia> m_prefs\n4x4 Array{Int64,2}:\n 1  3  1  2\n 2  1  3  3\n 3  2  2  1\n 0  0  0  0\n\njulia> f_prefs\n5x3 Array{Int64,2}:\n 1  2  3\n 2  3  4\n 4  1  1\n 3  4  2\n 0  0  0\n\njulia> s_prefs, c_prefs, caps = random_prefs(4, 3, ReturnCaps);\n\njulia> s_prefs\n4x4 Array{Int64,2}:\n 2  1  2  1\n 1  3  1  0\n 3  2  3  3\n 0  0  0  2\n\njulia> c_prefs\n5x3 Array{Int64,2}:\n 3  4  1\n 0  1  4\n 4  3  0\n 1  2  3\n 2  0  2\n\njulia> caps\n3-element Array{Int64,1}:\n 1\n 2\n 2\n\n\n\n"
},

{
    "location": "api/Matching.html#Exported-1",
    "page": "Matching",
    "title": "Exported",
    "category": "section",
    "text": "Modules = [Matching]\nPrivate = false"
},

{
    "location": "api/Matching.html#Matching._randperm!-Tuple{AbstractRNG,AbstractArray{T<:Integer,1}}",
    "page": "Matching",
    "title": "Matching._randperm!",
    "category": "Method",
    "text": "Given a vector a of length n, generate a random permutation of length n and store it in a.\n\n\n\n"
},

{
    "location": "api/Matching.html#Matching._randperm2d!-Tuple{AbstractRNG,AbstractArray{T<:Integer,2}}",
    "page": "Matching",
    "title": "Matching._randperm2d!",
    "category": "Method",
    "text": "Given an m x n matrix a, generate n random permutations of length m and store them in columns of a.\n\n\n\n"
},

{
    "location": "api/Matching.html#Matching.rand_lt",
    "page": "Matching",
    "title": "Matching.rand_lt",
    "category": "Function",
    "text": "Return a random Int (masked with mask) in 0 n), when n <= 2^52.\n\n\n\n"
},

{
    "location": "api/Matching.html#Internal-1",
    "page": "Matching",
    "title": "Internal",
    "category": "section",
    "text": "Modules = [Matching]\nPublic = false"
},

{
    "location": "api/Matching.html#Index-1",
    "page": "Matching",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"Matching.md\"]"
},

]}
