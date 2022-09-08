#include <stdio.h>
#include <stdlib.h>
#include "pd_api.h"

#ifdef _WINDLL
	__declspec(dllexport)
#endif

#ifdef TARGET_PLAYDATE
	void privEsc(void) __attribute__((naked));
	void privEsc() {
		__asm volatile(
			"nop\n"
			"nop\n"
			"nop\n"
			"nop\n"
			"nop\n"); //redacted
	}
#endif

PlaydateAPI* pd;
char unlockKey[32] = "This only works on real devices.";

int eventHandler(PlaydateAPI *pd, PDSystemEvent event, uint32_t arg) {
	(void) arg;
	if (event == kEventInit) {
		#ifdef TARGET_PLAYDATE
			privEsc();
			memcpy(unlockKey, (const char *) 0x1FF0F040, 0x20); //this will crash due to the redacted privEsc exploit
		#endif
		SDFile* file = pd->file->open("unlockkey.txt", kFileWrite);
		pd->file->write(file, unlockKey, strlen(unlockKey));
		pd->file->close(file);
		pd->system->logToConsole("Unlock key saved to unlockkey.txt.");
	}
	
	return 0;
}
