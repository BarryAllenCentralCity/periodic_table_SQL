#!/bin/bash

# Check if no argument is provided
if [ -z "$1" ]; then
    echo "Please provide an element as an argument."
    exit 0
fi

# Database connection details
DB_HOST="localhost"
DB_NAME="periodic_table"
DB_USER="freecodecamp"
DB_PASS="" # Assuming no password, adjust if necessary

# Function to get element details from the database
get_element_details() {
    local search_value=$1

    # Query the database for the element (search by atomic number, symbol, or name)
    SQL_QUERY="SELECT p.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
               FROM properties p
               LEFT JOIN types t ON t.type_id = p.type_id
               JOIN elements e ON e.atomic_number = p.atomic_number
               WHERE e.atomic_number::text = '$search_value'
                  OR e.symbol = '$search_value'
                  OR e.name = '$search_value';"

    # Run the SQL query using psql and capture the result
    result=$(psql -h $DB_HOST -d $DB_NAME -U $DB_USER -At -c "$SQL_QUERY")

    # Check if the result is empty (element not found)
    if [ -z "$result" ]; then
        echo "I could not find that element in the database."
        exit 0
    else
        # Parse the result and print the output in the desired format
        IFS='|' read -r atomic_number name symbol atomic_mass melting_point boiling_point type <<< "$result"

        # Format the atomic mass to remove trailing zeros
        formatted_mass=$(echo "$atomic_mass" | sed 's/\.0*$//')

        # Output the details in the required format
        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $formatted_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    fi
}

# Call the function to get element details
get_element_details "$1"
