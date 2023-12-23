void main() {
  //final sol = Solution();
  //final res = sol.majorityElement([1, 1, 1, 2, 2, 1, 2, 2, 7, 2]);
}

class Solution {
  int majorityElement(List<int> nums) {
    var count = 0;
    var candidate = 0;

    for (final n in nums) {
      if (count == 0) {
        candidate = n;
      }
      count += (n == candidate) ? 1 : -1;
    }
    return candidate;
  }
}
