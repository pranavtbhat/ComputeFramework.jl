export bsp

### Bulk Synchronous Parallel ###

immutable BSPNode <: ComputeNode
    f::Function
    seed::Int
    graph::SparseMatrixCSC{Int,Int}
end

# Perform necessary conversions
bsp(f,seed,graph) = BSPNode(f,seed,graph)

function compute(ctx, node::BSPNode)
    n, = size(node.graph)
    seed = node.seed
    f = node.f

    # load graph
    dgraph = compute(Context(), distribute(node.graph))

    # load activelist
    active = falses(n)
    active[seed] = true
    dactive = compute(Context(), distribute(active))

    # load distances
    dists = fill!(zeros(Int,n), -1)
    dists[seed] = 0
    ddists = compute(Context(),distribute(dists))

    # load message box
    messages = [ [] for p in workers()]
    dmessages = compute(Context(), distribute(messages))

    taskrefs = []

    for w in workers()
        # Find remote reference to worker's graph
        lgraph = dgraph.refs[w-1][2]
        lactive = dactive.refs[w-1][2]
        lmessages = dmessages.refs[w-1][2]
        ldists = ddists.refs[w-1][2]

        push!(taskrefs, remotecall(w, f, lgraph, lactive, lmessages, ldists))
    end

    for i in 1:length(taskrefs)
        println(i, fetch(taskrefs[i]))
    end
end
