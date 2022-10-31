#include<stdio.h>

int main()
{
	int total_level = 987654321, break_level = 123456789;
	int drop_cnt = 0, drop_egg = 0, drop_final;

	int low = 0, high = total_level, center;
	while (1)
	{
		if (low +1 == high){
			if (high > break_level)
			{
				drop_final = 0;
				drop_egg++;
			}
			else
				drop_final = 1;

			drop_cnt++;
			break;
		}
		center = (low + high) / 2;
		if (center > break_level) {
			high = center;
			drop_egg++;
		}
		else
			low = center;

		drop_cnt++;
	}

	printf("drop_cnt:%d,drop_egg:%d,final:%s.\n", drop_cnt, drop_egg, !drop_final ? "break" : "not break");
	return 0;
}