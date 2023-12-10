#include <iostream>
#include <stdint.h>
#include <bitset>
using namespace std;

/* take 64 bits of data in v[0] and v[1] and 128 bits of key[0] - key[3] */

void encipher(unsigned int num_rounds, uint32_t v[2], uint32_t const key[4]) {
    unsigned int i;
    uint32_t v0=v[0], v1=v[1], sum=0, delta=0x9E3779B9;
    for (i=0; i < num_rounds; i++) {
        cout<<"i: "<<i<<endl;
        v0 += (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + key[sum & 3]);
        cout<<hex<<((((v1 << 4) ^ (v1 >> 5)) + v1))<<endl;
        cout<<hex<<(sum + key[sum & 3])<<endl;
        cout<<hex<<((((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + key[sum & 3]))<<endl;
        cout<<"0: "<<hex<<v0<<endl;
        cout<<"keysel: "<<hex<<(sum&3)<<endl;
        sum += delta;
        cout<<"sum: "<<bitset<32>(sum)<<endl;
        v1 += (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + key[(sum>>11) & 3]);
        cout<<hex<<((((v0 << 4) ^ (v0 >> 5)) + v0))<<endl;
        cout<<hex<<((sum + key[(sum>>11) & 3]))<<endl;
        cout<<hex<<((((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + key[(sum>>11) & 3]))<<endl;
        cout<<"1: "<<hex<<v1<<endl;
        cout<<"keysel: "<<hex<<((sum>>11)&3)<<endl;
        cout<<endl;
    }
    v[0]=v0; v[1]=v1;
    cout<<hex<<v[0]<<endl;
    cout<<hex<<v[1]<<endl;
}
void decipher(unsigned int num_rounds, uint32_t v[2], uint32_t const key[4]) {
    unsigned int i;
    uint32_t v0=v[0], v1=v[1], delta=0x9E3779B9, sum=delta*num_rounds;
    cout<<"test: "<<sum<<endl;
    for (i=0; i < num_rounds; i++) {
        cout<<i<<endl;
        v1 -= (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + key[(sum>>11) & 3]);
        cout<<hex<<(((v0 << 4) ^ (v0 >> 5)) + v0)<<endl;
        cout<<(sum + key[(sum>>11) & 3])<<endl;
        cout<<"1: "<<hex<<v1<<endl;
        sum -= delta;
        cout<<"sum: "<<hex<<sum<<endl;
        v0 -= (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + key[sum & 3]);
        cout<<"0: "<<hex<<v0<<endl;
    }
    v[0]=v0; v[1]=v1;
    cout<<hex<<v[0]<<endl;
    cout<<hex<<v[1]<<endl;
}

int main(){
    // cout<<bitset<32>(0xAAAAAAAA)<<endl;
    uint32_t msg[2] = {0b01101000011001010110110001101100, 0b01101111001100010011001000110011};
    uint32_t key[4] = {
        0b00110001001100100011001100110100, 
        0b00110101001101100011011100111000, 
        0b00110001001100100011001100110100, 
        0b00110101001101100011011100111000
    };
    // cout<<"hello"<<endl;
    encipher(32, msg, key);
    // cout<<bitset<32>(0x9e5eeedf)<<endl;
    // cout<<bitset<32>(0xb7abac28)<<endl;

    // uint32_t msg2[2] = {0x9e5eeedf, 0xb7abac28};
    // decipher(32, msg2, key);
}