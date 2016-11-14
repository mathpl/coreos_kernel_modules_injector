# coreos_kernel_modules_injector

Going from the coreos dev container to workable modules and binaries, in a few steps.

# Guestfish image:
1. Fetch coreos_developer_container.VERSION.bin.bz2 from CoreOS repo.
2. Convert to docker image for that version with guestfish.

# kbuilder image:
1. Using the converted image: setup emerge, kernel modules and minimal build tools.

From there we do our builds. Currently in tree:

# ZFS
1. Using kbuilder image.
2. emerge zlib (dependancy)
3. Fetch spl + zfs with the specified version.
4. Build both.
5. Copy them out of the container.
6. Build a much smaller injector image with the modules and binaries.
7. Run image on coreos with the proper docker parameters.

# Dahdi
1. Using kbuilder image.
3. Fetch dahdi with the specified version.
4. Build it.
5. Copy modules out of the container.
6. Build a much smaller injector image with the modules.
7. Run image on coreos with the proper docker parameters.


