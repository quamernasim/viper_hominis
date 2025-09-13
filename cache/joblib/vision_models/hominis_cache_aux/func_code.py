# first line: 766
@cache.cache(ignore=['result'])
def hominis_cache_aux(fn_name, prompts, temperature, n_votes, result):
    """
    This is a trick to manually cache results from GPT-3. We want to do it manually because the queries to GPT-3 are
    batched, and caching doesn't make sense for batches. With this we can separate individual samples in the batch
    """
    return result
