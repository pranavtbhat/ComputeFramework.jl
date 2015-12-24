addprocs(2)

using ComputeFramework

function bfsVisitor(lgraph, lactive, lmessages, ldists)
    #fetch data
    graph = fetch(lgraph)
    active = fetch(lactive)
    messages = fetch(lmessages)
    dists = fetch(ldists)
end

m = sparse(ones(10,10))
node = bsp(+, 1, m)
compute(Context(), node)
