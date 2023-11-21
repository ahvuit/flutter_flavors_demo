package com.ahvuit.demo_flavors.models

class User {
    private val id: String
    val email: String
    private val userName: String

    constructor(id: String, email: String, userName: String) {
        this.id = id
        this.email = email
        this.userName = userName
    }
}