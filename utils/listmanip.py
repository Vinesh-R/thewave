def split_list(nums, n):
    return [nums[i:i + n] for i in range(0, len(nums), n)]

def tuple2list(lst) :
    return [x[0] for x in lst]