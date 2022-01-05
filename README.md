# Caesar and Vigenere Ciphers

Use the Run I/O console to encrypt and decrypt text using a simple ciphers. Specifically, encrypt and decrypt text with a Vigenere cipher, which is a simple extension of the well know Caesar cipher, where letters are shifted by a given number. For instance a shift of 3 would change an A to D. At the end of the alphabet, we wrap back to the beginning, so a shift of 3 also changes a Z to C.

Assume that all text is ASCII, and we will work only with capital letters. The key will also be written using letters where A corresponds to a shift of 0, B to 1, C to 2, and so on. Decryption is done by simply shifting instead by a negative amount.

In a Vigenere cipher, to use a key with multiple letters, we repeat the key over and over again. Where the plain text contains spaces and punctuation, we will leave the text unchanged, and skip to the next letter in the key and the next letter in the text. For instance ”LET’S GO TO THE CAT MUSEUM!” with key ”AB” will becomes ”LFT’S GP UO TIE CBT MVSFUN!”, that is, letters in even positions starting at position zero are not shifted, while letters in odd positions are shifted by 1.

There are many interesting ways to try to break Vigenere ciphers, but among the most simple is to look at letter frequencies. Here we compute the frequencies of letters to try to identify the key, but this will not be an entirely automatic process. For a given guess, you will need to also specify an assumed length of the key and what letter you believe to be most probable. While the letter E is most common in large blocks of English text, other letters are also very common. See the Figure inset below.

![image](https://user-images.githubusercontent.com/68981504/148159188-f643dc85-6fc8-46a4-9f09-5cbe9cab3e72.png)
