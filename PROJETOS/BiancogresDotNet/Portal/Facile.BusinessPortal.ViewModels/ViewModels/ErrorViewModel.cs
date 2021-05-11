using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Microsoft.AspNetCore.Mvc;
using System;

namespace Facile.BusinessPortal.ViewModels
{
    public enum ErroType
    {
        Access = 1,
        Exception = 2,
        Validation = 3
    }

    public class ErrorViewModel
    {
        public ErroType ErrorType { get; set; }

        public string RequestId { get; set; }

        public string UserId { get; set; }

        public string RequestPath { get; set; }

        public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);

        public bool ShowUserId => !string.IsNullOrEmpty(UserId);

        public string ErrorTitle { get; set; }

        public string ErrorDescription { get; set; }

        public string ErrorDetails { get; set; }

        public string ControllerName { get; set; }

        public string ControllerAction { get; set; }

        private ErrorViewModel()
        {
        }

        private ErrorViewModel(ErroType type)
        {
            ErrorType = type;

            if (type == ErroType.Access)
            {
                ErrorTitle = "Sem Acesso";
                ErrorDescription = "Você não tem acesso a esta função";
            }
            else
            {
                ErrorTitle = "ERRO";
                ErrorDescription = "Ocorreu um erro inesperador";
            }
        }

        private ErrorViewModel(ErroType type, string _descriprion)
        {
            ErrorType = type;

            if (type == ErroType.Access)
            {
                ErrorTitle = "Sem Acesso";
                ErrorDescription = _descriprion;
            }
            else if (type == ErroType.Validation)
            {
                ErrorTitle = "Operação Inválida";
                ErrorDescription = _descriprion;
            }
            else
            {
                ErrorTitle = "ERRO";
                ErrorDescription = _descriprion;
            }
        }

        public ErrorViewModel(ErroType type, string controllerName, string controllerAction) : this(type)
        {
            ControllerName = controllerName;
            ControllerAction = controllerAction;
        }

        public ErrorViewModel(ErroType type, ControllerContext controllerContext) : this(type)
        {
            if (controllerContext != null)
            {
                ControllerName = controllerContext.ActionDescriptor.ControllerName;
                ControllerAction = controllerContext.ActionDescriptor.ActionName;
            }
        }

        public ErrorViewModel(ErroType type, string _descriprion, ControllerContext controllerContext) : this(type, _descriprion)
        {
            if (controllerContext != null)
            {
                ControllerName = controllerContext.ActionDescriptor.ControllerName;
                ControllerAction = controllerContext.ActionDescriptor.ActionName;
            }
        }

        private ErrorViewModel(Exception ex)
        {
            if (ex is AccessException)
            {
                ErrorType = ErroType.Access;
                ErrorTitle = "SEM ACESSO";
                ErrorDescription = "Sem acesso a funcionalidade";
                ErrorDetails = ex.Message;
            }
            else
            {
                ErrorType = ErroType.Exception;
                ErrorTitle = "FALHA INTERNA";
                ErrorDescription = "Ocorreu um erro interno do sistema";
                ErrorDetails = ErroUtil.GetTextoCompleto(ex);
            }            
        }

        public ErrorViewModel(Exception ex, ControllerContext controllerContext) : this(ex)
        {
            if (controllerContext != null)
            {
                ControllerName = controllerContext.ActionDescriptor.ControllerName;
                ControllerAction = controllerContext.ActionDescriptor.ActionName;
            }
        }

        public ErrorViewModel(Exception ex, string controllerName, string controllerAction) : this(ex)
        {
            ControllerName = controllerName;
            ControllerAction = controllerAction;
        }
    }

    public class AccessErrorViewModel : ErrorViewModel
    {
        public AccessErrorViewModel(ControllerContext controllerContext) : base(ErroType.Access, controllerContext)
        {
        }

        public AccessErrorViewModel(string controllerName, string controllerAction) : base(ErroType.Access, controllerName, controllerAction)
        {
        }

        public AccessErrorViewModel(Exception ex, ControllerContext controllerContext) : base(ex, controllerContext)
        {
            ErrorDetails = ErroUtil.GetTextoCompleto(ex);
        }

        public AccessErrorViewModel(Exception ex, string controllerName, string controllerAction) : base(ex, controllerName, controllerAction)
        {
            ErrorDetails = ErroUtil.GetTextoCompleto(ex);
        }
    }
}
