# wrk -t12 -d30s -c400 -s ./post-sparse.lua "http://$1/sparse_encode"
wrk -t12 -d30s -c400 -s ./post-dense.lua "http://$1/embeddings"
