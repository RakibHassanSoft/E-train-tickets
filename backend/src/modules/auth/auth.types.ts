export interface RegisterInput {
    first_name: string;
    last_name: string;
    email: string;
    phone: string;
    password: string;
}

export interface LoginInput {
    email: string;
    password: string;
}
