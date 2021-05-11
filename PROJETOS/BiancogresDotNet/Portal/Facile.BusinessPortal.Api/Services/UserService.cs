using System;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.Model;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Facile.BusinessPortal.Api.Services
{
    public interface IUserService
    {
        AccessReturn Authenticate(ClientAuth auth);
    }

    public class UserService : IUserService
    {
        private readonly AppSettings _appSettings;
        private readonly FBContext _context;

        public UserService(IOptions<AppSettings> appSettings, FBContext context)
        {
            _appSettings = appSettings.Value;
            _context = context;
        }

        public AccessReturn Authenticate(ClientAuth auth)
        {
            AccessReturn access = null;

            if (!Guid.TryParse(auth.Client_Key, out var guid))
            {
                access = new AccessReturn() { Ok = false, Message = "Chave de Acesso Formato Inválido." };
                return access;
            }

            var unidade = _context.Unidade.SingleOrDefault(x => x.Empresa.Client_Key == guid && x.Secret_Key == auth.Secret_Key);

            // return null if user not found
            if (unidade == null)
                return null;

            // authentication successful so generate jwt token
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_appSettings.Secret);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[]
                {
                    new Claim(ClaimTypes.Name, unidade.CNPJ)
                }),
                NotBefore = DateTime.UtcNow,
                Expires = DateTime.UtcNow.AddDays(30),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);

            access = new AccessReturn
            {
                CNPJ = unidade.CNPJ,
                Nome = unidade.Nome,
                Token = tokenHandler.WriteToken(token)
            };

            return access;
        }
    }
}
