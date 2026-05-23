package com.example;

public class App {
    public static void main(String[] args) {
        // This will cause a compilation error - undefined class
        NonExistentClass obj = new NonExistentClass();
    }
}