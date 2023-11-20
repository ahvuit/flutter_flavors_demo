package com.ahvuit.demo_flavors.models

class User {
    val id: String?
    val email: String?
    val userName: String?

    constructor(id: String?, email: String?, userName: String?) {
        this.id = id
        this.email = email
        this.userName = userName
    }
}