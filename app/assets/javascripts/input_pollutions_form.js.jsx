class InputError extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      message: 'Input is invalid'
    };
  }
  render(){ 
    var errorClass = classNames(this.props.className, {
      'error_container':   true,
      'visible':           this.props.visible,
      'invisible':         !this.props.visible
    });
    return (
      <div className={errorClass}>
        <span>{this.props.errorMessage}</span>
      </div>
    );
  }
}

class OptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.props.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.value} value={op.value}>{op.label}</option>;
        })
      }
    </select>;
  }
}

class InputForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      weather: this.props.weather,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }
  render(){
    const terms = [
      { value: '01', label: '01' },
      { value: '07', label: '07' },
      { value: '13', label: '13' },
      { value: '19', label: '19' }
    ];
    var self = this;
    return(
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <p>Срок:
          <OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms" defaultValue="00"/>
          <span style={{color: 'red'}}>{this.props.errors.terms}</span>
        </p>
        <h3>Данные о погоде</h3>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Температура воздуха</th>
              <th>Скорость ветра</th>
              <th>Направление ветра</th>
              <th>Атмосферные явления</th>
              <th>Относительная влажность</th>
              <th>Парциальное давление</th>
              <th>Атмосферное давление</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <OptionSelect options={this.stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" />
              </td>
              {self.row1.map(function(td) {
                return(<td key={td}>
                  <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} />
                  <InputError visible={self.state[td].errorVisible} errorMessage="Ошибка!" />
                </td>);
              })}
            </tr>
          </tbody>
        </table>  
      </form>
    );
  }
    
}
class InputPollutionsForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      weather: this.props.weather,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(telegram) {
    var that = this;
    var telegrams = that.state.telegrams;
    var newTelegrams = [telegram].concat(telegrams);
    $.ajax({
      type: 'POST',
      dataType: 'json',
      url: "create_synoptic_telegram?t_term="+telegram["Срок"]+"&t_text="+telegram["Телеграмма"]
      }).done(function(data) {
        // alert(data["Дата"])
        newTelegrams[0]["Дата"] = data["Дата"];
        that.setState({telegrams: newTelegrams, errors: {}});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: res.responseJSON.errors});
      }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <h3>Создать новую телеграмму</h3>
        <InputForm onInputFormSubmit={this.handleFormSubmit} weather = {this.state.weather} errors = {this.state.errors} />
      </div>
    );
  }
}