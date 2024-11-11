#include <stdio.h>
#include <sys/sysctl.h>
#import <Foundation/Foundation.h>

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        reboot(0);
		return 0;
	}
}
