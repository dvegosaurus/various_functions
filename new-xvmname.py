def new_xvmname(vms, os, vm_env, customer, number_of_names=1):
    digit = 1  # initialize the lowest digit
    max_digit = 3  # 000
    nonamefound = True
    names = []

    while nonamefound:
        # convert a digit to a string with a length of max_digit
        number_to_string = str(digit).zfill(max_digit)

        # generate a vm name
        name = f"{customer}-{vm_env}{os}APP{number_to_string}"

        if name not in vms:
            names.append(name)  # if the vm name does not exist > add it to the list of available names
        if number_of_names == len(names):  # if we reached the number of names we want > return the data
            return names

        digit += 1

# Example usage:
vms = [
    "HORI-PWAPP001",
    "HORI-PWAPP002",
    "HORI-PWAPP003"
]  # provide the list of existing VM names
result = new_xvmname(vms, os="W", vm_env="P", customer="HORI", number_of_names=10)
print(result)
