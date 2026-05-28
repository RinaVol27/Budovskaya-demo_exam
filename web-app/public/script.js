id="c7f5" 
const registerForm = document.getElementById('registerForm'); 

if(registerForm){ 
    registerForm.addEventListener( 'submit', async(e)=>{ e.preventDefault(); 
        const data = { 
            full_name: document.getElementById('full_name').value, 
            login: document.getElementById('login').value, 
            email: document.getElementById('email').value, 
            phone: document.getElementById('phone').value, 
            password: document.getElementById('password').value 
        }; 
        
        const response = await fetch( '/register', { 
            method:'POST', headers:{ 'Content-Type':'application/json' }, 
            body:JSON.stringify(data) 
        } ); 
        
        const result = await response.json(); alert(result.message); } ); } 

        const loginForm = document.getElementById('loginForm'); 
        if(loginForm){ loginForm.addEventListener( 'submit', async(e)=>{ e.preventDefault(); 
            const data = { 
                email: document.getElementById('loginEmail').value, 
                password: document.getElementById('loginPassword').value 
            }; 
            const response = await fetch( '/login', { 
                method:'POST', headers:{ 'Content-Type':'application/json' }, 
                body:JSON.stringify(data) 
            } ); 
            const result = await response.json(); 
            
            if(result.token){

                localStorage.setItem(
                    'token',
                    result.token
                );

                alert('Вход выполнен');

                // Переход на главную страницу
                window.location.href = 'index.html';

            }
            else{ alert(result.message); } 
            
            } 
        ); 
    }