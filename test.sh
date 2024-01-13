wrk -t12 -d30s -c40 -s ./scripts/post-sparse.lua "http://$1/sparse_encode"
sleep 120
wrk -t12 -d30s -c40 -s ./scripts/post-dense.lua "http://$1/embeddings"
