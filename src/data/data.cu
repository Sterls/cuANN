#include "data.hpp"
namespace cuANN
{

row::row ( unsigned int in_size, unsigned int out_size )
{
    input.resize( in_size );
    output.resize( out_size );
}


data::data ( const std::string filename )
{
    std::ifstream fs;
    fs.open( filename.c_str(), std::ios::in );
    if( !fs )
        throw std::runtime_error ("cuANN::data::data could not open file: " + filename );

    // line will serve as our tmp buffer
    std::string line;

    // read header
    std::getline(fs, line);
    std::istringstream iss(line);
    std::vector<unsigned int> header_values;
    std::copy( std::istream_iterator<unsigned int>(iss),
               std::istream_iterator<unsigned int>(),
               std::back_inserter(header_values)        );

    // Error check header
    if ( header_values.size() != 3 )
        throw std::runtime_error("cuANN::data file: `" 
                                 + filename + 
                                "` has malformed header");

    // If the header isn't malformed this should work
    num_rows_ = header_values.at( 0 );
    in_vec_size_ = header_values.at( 1 );
    out_vec_size_ = header_values.at( 2 );
    // reserve rows
    rows_.reserve( num_rows_ );
    // input/output flag
    bool flag = true;

    // start reading content
    while ( std::getline(fs, line) )
    {
        // Stream from line & iterate whitespaces as floats
        std::istringstream ss(line);
        std::istream_iterator<float> begin(ss), end;

        // An input row
        if ( flag )
        {
             // Create a new row and push it back
            rows_.push_back( row{in_vec_size_, out_vec_size_} );
            // copy into input vector the float sequence
            thrust::copy( begin, end, rows_.back().input.begin() );
            flag = false;
        }
        // An output row
        else if (!flag)
        {
            // copy into output vector the float sequence
            thrust::copy( begin, end, rows_.back().output.begin() );
            flag = true;
        }
    }

    fs.close();
    /*
    std::cout << "loaded: " << rows_.size() << " rows of data" << std::endl;
    std::cout << num_rows_ << " " << in_vec_size_ << " " << out_vec_size_ << std::endl;
    for ( const auto & pair : rows_ )
    {
        thrust::copy( pair.input.begin(), pair.input.end(), std::ostream_iterator<float>(std::cout, " "));
        std::cout << std::endl;
        thrust::copy( pair.output.begin(), pair.output.end(), std::ostream_iterator<float>(std::cout, " "));
        std::cout << std::endl;
    }
    */
}

}